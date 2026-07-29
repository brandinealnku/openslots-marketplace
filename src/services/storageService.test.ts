import {describe, expect, it} from 'vitest';
import {validatePhoto, validateProviderDocument} from './storageService';

describe('private upload validation', () => {
  it('accepts supported image MIME types without trusting a filename', () => {
    expect(() => validatePhoto({type: 'image/webp', size: 1024})).not.toThrow();
  });

  it('rejects unsupported and oversized photos', () => {
    expect(() => validatePhoto({type: 'image/svg+xml', size: 1024})).toThrow('JPEG');
    expect(() => validatePhoto({type: 'image/jpeg', size: 8 * 1024 * 1024 + 1})).toThrow('8 MB');
  });

  it('permits PDF provider documents but enforces their size boundary', () => {
    expect(() => validateProviderDocument({type: 'application/pdf', size: 2048})).not.toThrow();
    expect(() => validateProviderDocument({type: 'application/pdf', size: 12 * 1024 * 1024 + 1})).toThrow('12 MB');
  });
});
