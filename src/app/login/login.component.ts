import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import CryptoJS from 'crypto-js';
import { AuthService } from '../auth.service';
import { Router } from '@angular/router';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './login.component.html'
})
export class LoginComponent {
  invalid = false;
  constructor(
    readonly auth: AuthService,
    private readonly http: HttpClient,
    private readonly router: Router
  ) {}
  login() {
    this.http
      .get('/assets/password.txt', { responseType: 'text' })
      .subscribe((encrypted) => {
        if (this.auth.password) {
          try {
            let decrypted = CryptoJS.AES.decrypt(
              encrypted,
              this.auth.password ?? ''
            ).toString(CryptoJS.enc.Utf8);
            if (this.auth.password === decrypted) {
              this.invalid = false;
              this.auth.password = decrypted;
              this.router.navigate(['hotelinfo']);
            } else this.invalid = true;
          } catch {
            this.invalid = true;
          }
        } else this.invalid = true;
      });
  }
}
