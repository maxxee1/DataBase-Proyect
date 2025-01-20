import { neon } from '@neondatabase/serverless';

export const sql = neon(
  'postgresql://neondb_owner:Ro6QCybEcq0U@ep-muddy-cherry-a5ltuozi.us-east-2.aws.neon.tech/neondb?sslmode=require',
);
