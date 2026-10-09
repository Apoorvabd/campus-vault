import { AppError } from "../../utils";
import type { SaveMySubjectsInput } from "./subjects.validation";
import {
  findFormOptions,
  findSemesterSubjects,
  findSubjectsByIds,
  findUserSubjectState,
  saveUserSubjects,
  searchSubjects,
  sortSubjects,
} from "./subjects.repository";

const getState = async (userId: string) => {
  const state = await findUserSubjectState(userId);
  if (!state) throw new AppError("User not found.", 404);
  return state;
};

const isConfirmedForCurrentSemester = (
  state: Awaited<ReturnType<typeof getState>>
) =>
  state.subjectsConfirmedAt !== null &&
  state.subjectsSemester === state.currentSemester;

// The subjects shown on Home: the user's own picks once confirmed for this
// semester, otherwise everything the course lists for the semester.
export const getMySubjectsService = async (userId: string) => {
  const state = await getState(userId);
  const subjects = isConfirmedForCurrentSemester(state)
    ? await findSubjectsByIds(state.selectedSubjectIds)
    : await findSemesterSubjects(state.courseId, state.currentSemester);
  return sortSubjects(subjects);
};

// Everything the setup form needs: pre-filled picks plus dropdown options.
export const getSubjectsFormService = async (userId: string) => {
  const state = await getState(userId);
  const options = await findFormOptions(
    state.courseId,
    state.universityId,
    state.currentSemester
  );

  const confirmed = isConfirmedForCurrentSemester(state);
  // Before the first save only the DSC are pre-filled: the other types are
  // personal choices, not something the course dictates.
  const current = confirmed
    ? await findSubjectsByIds(state.selectedSubjectIds)
    : (await findSemesterSubjects(state.courseId, state.currentSemester)).filter(
        (s) => s.type === "DSC"
      );

  const byType = (type: string) =>
    sortSubjects(options.filter((s) => s.type === type));
  const picked = (type: string) =>
    sortSubjects(current.filter((s) => s.type === type)).map((s) => s.id);

  return {
    semester: state.currentSemester,
    confirmed,
    selected: {
      dsc: picked("DSC").slice(0, 3),
      ge: picked("GE")[0] ?? null,
      dse: picked("DSE").slice(0, 2),
      sec: picked("SEC")[0] ?? null,
      vac: picked("VAC")[0] ?? null,
      aec: picked("AEC")[0] ?? null,
    },
    options: {
      dsc: byType("DSC"),
      ge: byType("GE"),
      dse: byType("DSE"),
      sec: byType("SEC"),
      vac: byType("VAC"),
      aec: byType("AEC"),
    },
  };
};

export const saveMySubjectsService = async (
  userId: string,
  input: SaveMySubjectsInput
) => {
  const state = await getState(userId);

  const dse = input.dse;
  const optional = [input.ge, input.sec, input.vac, input.aec].filter(
    (id): id is string => !!id
  );
  const ids = [...input.dsc, ...dse, ...optional];

  if (new Set(ids).size !== ids.length) {
    throw new AppError("Each subject can only be selected once.", 400);
  }
  // No GE this semester means the student takes a second DSE instead
  if (dse.length > (input.ge ? 1 : 2)) {
    throw new AppError(
      input.ge
        ? "Only 1 DSE is allowed when you have a GE."
        : "At most 2 DSE subjects are allowed.",
      400
    );
  }

  const found = await findSubjectsByIds(ids);
  const byId = new Map(found.map((s) => [s.id, s]));

  // DSC / DSE come from the student's own course; the rest are shared across
  // the university (see findFormOptions).
  const expect = (list: string[], type: string, label: string) => {
    const ownCourseOnly = type === "DSC" || type === "DSE";
    for (const id of list) {
      const subject = byId.get(id);
      const allowed =
        subject &&
        (ownCourseOnly
          ? subject.courseId === state.courseId
          : subject.course.universityId === state.universityId);
      if (!subject || !allowed) {
        throw new AppError(`Invalid ${label} subject selected.`, 400);
      }
      if (subject.type !== type) {
        throw new AppError(`${subject.name} is not a ${label} subject.`, 400);
      }
    }
  };
  expect(input.dsc, "DSC", "DSC");
  expect(dse, "DSE", "DSE");
  expect(input.ge ? [input.ge] : [], "GE", "GE");
  expect(input.sec ? [input.sec] : [], "SEC", "SEC");
  expect(input.vac ? [input.vac] : [], "VAC", "VAC");
  expect(input.aec ? [input.aec] : [], "AEC", "AEC");

  await saveUserSubjects(userId, {
    selectedSubjectIds: ids,
    subjectsSemester: state.currentSemester,
  });

  return sortSubjects(ids.map((id) => byId.get(id)!));
};

export const MIN_SEARCH_LENGTH = 4;

export const searchSubjectsService = async (userId: string, query: string) => {
  const q = query.trim();
  if (q.length < MIN_SEARCH_LENGTH) {
    throw new AppError(
      `Type at least ${MIN_SEARCH_LENGTH} characters to search.`,
      400
    );
  }
  const state = await getState(userId);
  return searchSubjects(state.universityId, q, 20);
};
