import {supabaseRequest} from '../lib/supabase';

const PHOTO_TYPES = new Map([
  ['image/jpeg', 'jpg'],
  ['image/png', 'png'],
  ['image/webp', 'webp'],
]);
const DOCUMENT_TYPES = new Map([
  ...PHOTO_TYPES,
  ['application/pdf', 'pdf'],
]);

export function validatePhoto(file: Pick<File, 'type' | 'size'>) {
  if (!PHOTO_TYPES.has(file.type)) throw new Error('Use a JPEG, PNG, or WebP image.');
  if (file.size > 8 * 1024 * 1024) throw new Error('Images must be 8 MB or smaller.');
}

export function validateProviderDocument(file: Pick<File, 'type' | 'size'>) {
  if (!DOCUMENT_TYPES.has(file.type)) throw new Error('Use a PDF, JPEG, PNG, or WebP document.');
  if (file.size > 12 * 1024 * 1024) throw new Error('Documents must be 12 MB or smaller.');
}

function randomizedPath(userId: string, scope: string, type: string, allowed: Map<string, string>) {
  const extension = allowed.get(type);
  if (!extension) throw new Error('Unsupported file type.');
  return `${userId}/${scope}/${crypto.randomUUID()}.${extension}`;
}

async function upload(bucket: string, path: string, file: File, token: string) {
  await supabaseRequest(`storage/v1/object/${bucket}/${path}`, {
    method: 'POST',
    headers: {'Content-Type': file.type, 'x-upsert': 'false'},
    body: file,
  }, token);
  return path;
}

export const storageService = {
  uploadBookingPhoto: async (file: File, userId: string, bookingId: string, token: string) => {
    validatePhoto(file);
    return upload('booking-photos', randomizedPath(userId, bookingId, file.type, PHOTO_TYPES), file, token);
  },
  uploadProviderDocument: async (file: File, userId: string, token: string) => {
    validateProviderDocument(file);
    return upload('provider-documents', randomizedPath(userId, 'documents', file.type, DOCUMENT_TYPES), file, token);
  },
  createSignedUrl: (bucket: 'booking-photos' | 'provider-documents' | 'avatars', path: string, token: string, expiresIn = 300) =>
    supabaseRequest<{signedURL: string}>(`storage/v1/object/sign/${bucket}/${path}`, {
      method: 'POST', body: JSON.stringify({expiresIn: Math.min(Math.max(expiresIn, 60), 900)}),
    }, token),
  remove: (bucket: 'booking-photos' | 'provider-documents' | 'avatars', paths: string[], token: string) =>
    supabaseRequest(`storage/v1/object/${bucket}`, {method: 'DELETE', body: JSON.stringify({prefixes: paths})}, token),
};
