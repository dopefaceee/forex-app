import { requireAuth } from '$lib/auth';
import type { LayoutLoad } from './$types';

export const load: LayoutLoad = async () => {
  // This will redirect to '/' if user is not authenticated
  const session = await requireAuth();
  
  return {
    session
  };
};