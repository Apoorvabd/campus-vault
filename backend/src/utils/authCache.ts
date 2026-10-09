import type { Request } from "express";

type AuthUser = NonNullable<Request["user"]>;

// The login check used to hit the database on EVERY request (~200 ms when the
// database is far away). We remember the user for a short time instead.
const TTL_MS = 30_000;
const MAX_ENTRIES = 2_000;

const cache = new Map<string, { user: AuthUser; expiresAt: number }>();

export const getCachedAuthUser = (userId: string): AuthUser | undefined => {
  const hit = cache.get(userId);
  if (!hit) return undefined;
  if (hit.expiresAt < Date.now()) {
    cache.delete(userId);
    return undefined;
  }
  return hit.user;
};

export const setCachedAuthUser = (userId: string, user: AuthUser) => {
  if (cache.size >= MAX_ENTRIES) {
    // drop the oldest entry (Maps keep insertion order)
    const oldest = cache.keys().next().value;
    if (oldest !== undefined) cache.delete(oldest);
  }
  cache.set(userId, { user, expiresAt: Date.now() + TTL_MS });
};

/** Call after something changes that the login check reads (profile edit, role...). */
export const invalidateAuthUser = (userId: string) => {
  cache.delete(userId);
};
