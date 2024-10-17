import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Inject, Injectable } from '@angular/core';
import { firstValueFrom } from 'rxjs';
import CryptoJS from 'crypto-js';
import { DOCUMENT } from '@angular/common';
import {
  ActivatedRouteSnapshot,
  CanActivate,
  GuardResult,
  MaybeAsync,
  Router,
  RouterStateSnapshot
} from '@angular/router';
import { ITimetable } from './itimetable';

@Injectable({ providedIn: 'root' })
export class SystemService implements CanActivate {
  constructor(
    @Inject(DOCUMENT) readonly document: Document,
    private readonly http: HttpClient,
    private readonly router: Router
  ) {}
  canActivate(
    route: ActivatedRouteSnapshot,
    state: RouterStateSnapshot
  ): MaybeAsync<GuardResult> {
    if (this.password) {
      return true;
    } else {
      this.router.navigate(['/login']);
      return false;
    }
  }
  get window() {
    return this.document.defaultView!;
  }
  get localStorage() {
    return this.window.localStorage;
  }
  private readonly secret = 'R0mulanWarb!rd';
  set password(value: string) {
    this.window.localStorage.setItem('data', this.encrypt(value, this.secret));
  }
  get password() {
    return this.decrypt(
      this.window.localStorage.getItem('data') ?? '',
      this.secret
    );
  }
  get loggedIn() {
    return !!this.password;
  }
  logout() {
    this.window.localStorage.removeItem('data');
    this.router.navigate(['/login']);
  }
  encrypt(value: string, cipher: string) {
    return CryptoJS.AES.encrypt(value, cipher).toString();
  }
  decrypt(value: string, cipher: string) {
    return CryptoJS.AES.decrypt(value, cipher).toString(CryptoJS.enc.Utf8);
  }
  async openEncryptedJsonFile<T>(filename: string): Promise<T> {
    let encrypted = await firstValueFrom(
      this.http.get(filename, {
        responseType: 'text',
        headers: new HttpHeaders({
          'Cache-Control': 'no-cache',
          Pragma: 'no-cache',
          Expires: 'Sat, 01 Jan 2000 00:00:00 GMT'
        })
      })
    );
    let data = this.decrypt(encrypted, this.password!);
    return JSON.parse(data);
  }
}
