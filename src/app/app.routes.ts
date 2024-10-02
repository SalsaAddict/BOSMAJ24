import { Routes } from '@angular/router';
import { HomeComponent } from './home/home.component';
import { GuestInfoComponent } from './guest-info/guest-info.component';
import { LoginComponent } from './login/login.component';
import { authGuard } from './auth.guard';

export const routes: Routes = [
  { path: 'login', component: LoginComponent },
  { path: 'hotelinfo', component: HomeComponent, canActivate: [authGuard] },
  {
    path: 'guestinfo',
    component: GuestInfoComponent,
    canActivate: [authGuard]
  },
  { path: '**', redirectTo: '/login' }
];
