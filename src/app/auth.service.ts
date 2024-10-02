import { HttpClient } from '@angular/common/http';
import { Inject, Injectable } from '@angular/core';
import { firstValueFrom } from 'rxjs';
import CryptoJS from 'crypto-js';
import { DOCUMENT } from '@angular/common';

@Injectable({ providedIn: 'root' })
export class AuthService {
  constructor(
    @Inject(DOCUMENT) private readonly document: Document,
    private readonly http: HttpClient
  ) {}
  private get window() {
    return this.document.defaultView!;
  }
  private readonly secret = 'R0mulanWarb!rd';
  set password(value: string) {
    this.window.localStorage.setItem('pw', this.encrypt(value, this.secret));
  }
  get password() {
    return this.decrypt(
      this.window.localStorage.getItem('pw') ?? '',
      this.secret
    );
  }
  encrypt(value: string, cipher: string) {
    return CryptoJS.AES.encrypt(value, cipher).toString();
  }
  decrypt(value: string, cipher: string) {
    return CryptoJS.AES.decrypt(value, cipher).toString(CryptoJS.enc.Utf8);
  }
  async openEncryptedJsonFile<T>(filename: string): Promise<T> {
    let encrypted = await firstValueFrom(
      this.http.get('/assets/hotelinfo.txt', { responseType: 'text' })
    );
    let data = this.decrypt(encrypted, this.password!);
    return JSON.parse(data);
  }
}
