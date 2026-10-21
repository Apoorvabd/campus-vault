/**
 * Adds the external PYQ links (dupyq + college sites) to the Resource table and hides the dead DU-QB rows they replace.
 *   npx tsx scripts/ingest-external-pyqs.ts          -> dry run (prints the plan only)
 *   npx tsx scripts/ingest-external-pyqs.ts --apply  -> writes
 * Undo: UPDATE "Resource" SET status='APPROVED', "rejectionReason"=NULL WHERE "rejectionReason"=<REPLACED_MARK>;
 *       DELETE FROM "Resource" WHERE source IN ('dupyq') OR source LIKE 'college:%';
 */
import { PrismaClient, ResourceStatus } from '@prisma/client';
import fs from 'fs';
const prisma = new PrismaClient();
const APPLY = process.argv.includes('--apply');
const SEED_USER = 'cmu34n6dr00019kihwsk561es';
const REPLACED_MARK = 'DU_QB_REPLACED_2026-10-22';
const read = (p: string) => JSON.parse(fs.readFileSync(p, 'utf8'));

type Cand = { course: string; code: string; url: string; session: string | null; set: string | null; source: string; status: ResourceStatus; name?: string };

(async () => {
  const cands: Cand[] = [];
  for (const r of read('../sources/dupyq/dupyq-selected-courses.json')) {
    if (!r.url) continue;
    for (const s of r.subjects) cands.push({ course: s.courseCode, code: s.subjectCode, url: r.url, session: r.session, set: r.set, source: 'dupyq', status: 'APPROVED' });
  }
  const GOOD = new Set(['upc-in-pdf', 'code-in-filename', 'manual-upc', 'name-exact']);
  const SKIP = ['not-a-question-paper', 'older-than-2020', 'ignored-by-owner', 'bundle-needs-split', 'bundle-many-papers'];
  for (const r of read('../sources/college-pyqs/college-pyqs.json')) {
    if (r.kind !== 'pdf' || !r.subjects.length || r.college === 'Kalindi' || r.mapMethod === 'bundle') continue;
    if (SKIP.some((f) => r.flags.includes(f))) continue;
    const loose = !GOOD.has(r.mapMethod) || r.flags.includes('course-ambiguous');
    for (const s of r.subjects) cands.push({ course: s.courseCode, code: s.subjectCode, url: r.url, session: r.session, set: r.set, source: `college:${r.college}${loose ? '-loose' : ''}`, status: loose ? 'PENDING' : 'APPROVED' });
  }
  const subs = await prisma.subject.findMany({ select: { id: true, code: true, name: true, course: { select: { code: true } } } });
  const sid = new Map(subs.map((s) => [`${s.course.code}|${s.code}`, s]));
  const existing = new Set((await prisma.resource.findMany({ select: { subjectId: true, externalUrl: true } })).map((e) => `${e.subjectId}|${e.externalUrl}`));

  const rows: any[] = []; const seen = new Set<string>(); let noSubject = 0, dup = 0;
  for (const c of cands) {
    const s = sid.get(`${c.course}|${c.code}`); if (!s) { noSubject++; continue; }
    const k = `${s.id}|${c.url}`; if (existing.has(k) || seen.has(k)) { dup++; continue; } seen.add(k);
    rows.push({ title: `${s.name} — ${c.session ?? 'Unknown session'}${c.set ? ` · ${c.set}` : ''}`, resourceType: 'PYQ', visibility: 'PUBLIC', status: c.status, sourceType: 'EXTERNAL_LINK',
      externalUrl: c.url, subjectId: s.id, uploadedById: SEED_USER, approvedById: c.status === 'APPROVED' ? SEED_USER : null, approvedAt: c.status === 'APPROVED' ? new Date() : null, source: c.source, _session: c.session });
  }
  const bySrc: Record<string, number> = {}; rows.forEach((r) => { const k = `${r.source} [${r.status}]`; bySrc[k] = (bySrc[k] ?? 0) + 1; });
  console.log('candidates', cands.length, '| no matching subject in DB', noSubject, '| already present / duplicate', dup, '| NEW rows', rows.length); console.table(bySrc);

  // dead qb rows that now have a live replacement for the same subject + session
  const live = new Set(rows.filter((r) => r.status === 'APPROVED' && r._session).map((r) => `${r.subjectId}|${r._session}`));
  const qb = await prisma.resource.findMany({ where: { source: 'du-qb', status: 'APPROVED' }, select: { id: true, subjectId: true, title: true } });
  const hide = qb.filter((q) => { const m = q.title.match(/(NOV-DEC|MAY-JUNE)-(\d{4})/); return m && live.has(`${q.subjectId}|${m[1]}-${m[2]}`); }).map((q) => q.id);
  console.log('dead qb rows replaced (will be hidden):', hide.length, 'of', qb.length, '| qb rows left as-is (no replacement):', qb.length - hide.length);
  if (!APPLY) { console.log('DRY RUN: nothing written. Re-run with --apply.'); await prisma.$disconnect(); return; }

  for (let i = 0; i < rows.length; i += 1000) {
    const chunk = rows.slice(i, i + 1000).map(({ _session, ...r }) => r);
    const res = await prisma.resource.createMany({ data: chunk, skipDuplicates: true }); console.log('inserted', i + res.count);
  }
  for (let i = 0; i < hide.length; i += 2000) await prisma.resource.updateMany({ where: { id: { in: hide.slice(i, i + 2000) } }, data: { status: 'PENDING', rejectionReason: REPLACED_MARK } });
  fs.writeFileSync('scripts/output/backups/hidden-qb-ids-2026-10-22.json', JSON.stringify(hide));
  console.log('DONE. hidden', hide.length);
  await prisma.$disconnect();
})();
