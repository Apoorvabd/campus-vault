import { PrismaClient } from '@prisma/client';
const p = new PrismaClient();
const MY: Record<string, string[]> = {};
(async () => {
  console.log('--- resources by source / status');
  console.table(await p.$queryRaw`SELECT COALESCE(source,'(none)') AS source, status::text, count(*)::int FROM "Resource" GROUP BY 1,2 ORDER BY 1,2`);
  console.log('--- subjects');
  console.table(await p.$queryRaw`
    SELECT count(*)::int AS subjects_total,
      count(*) FILTER (WHERE EXISTS (SELECT 1 FROM "Resource" r WHERE r."subjectId"=s.id AND r.status='APPROVED' AND COALESCE(r.source,'')<>'du-qb'))::int AS with_live_link,
      count(*) FILTER (WHERE NOT EXISTS (SELECT 1 FROM "Resource" r WHERE r."subjectId"=s.id AND r.status='APPROVED' AND COALESCE(r.source,'')<>'du-qb') AND EXISTS (SELECT 1 FROM "Resource" r WHERE r."subjectId"=s.id AND r.status='APPROVED'))::int AS only_dead_qb,
      count(*) FILTER (WHERE NOT EXISTS (SELECT 1 FROM "Resource" r WHERE r."subjectId"=s.id AND r.status='APPROVED'))::int AS nothing_visible
    FROM "Subject" s`);
  console.log('--- owner courses');
  console.table(await p.$queryRaw`
    SELECT c.code AS course, count(*)::int AS subjects,
      count(*) FILTER (WHERE EXISTS (SELECT 1 FROM "Resource" r WHERE r."subjectId"=s.id AND r.status='APPROVED' AND COALESCE(r.source,'')<>'du-qb'))::int AS live,
      count(*) FILTER (WHERE NOT EXISTS (SELECT 1 FROM "Resource" r WHERE r."subjectId"=s.id AND r.status='APPROVED' AND COALESCE(r.source,'')<>'du-qb') AND EXISTS (SELECT 1 FROM "Resource" r WHERE r."subjectId"=s.id AND r.status='APPROVED'))::int AS only_dead_qb
    FROM "Subject" s JOIN "Course" c ON c.id=s."courseId"
    WHERE c.code IN ('BC','BCP','BMS','BAPS','BAH','BAE-2','BSS','BSM','BSCS','BAAP','BAP-2','BAE','BVBO','BVSD','BSES')
    GROUP BY c.code ORDER BY c.code`);
  console.log('--- visible resources (what users see)');
  console.table(await p.$queryRaw`SELECT count(*) FILTER (WHERE status='APPROVED' AND COALESCE(source,'')='du-qb')::int AS visible_dead_qb, count(*) FILTER (WHERE status='APPROVED' AND COALESCE(source,'')<>'du-qb')::int AS visible_live, count(*) FILTER (WHERE status='PENDING')::int AS hidden_pending FROM "Resource"`);
  await p.$disconnect();
})();
