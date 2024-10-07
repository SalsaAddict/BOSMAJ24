import { Routes } from '@angular/router';
import { HomeComponent } from './home/home.component';
import { GuestInfoComponent } from './guest-info/guest-info.component';
import { LoginComponent } from './login/login.component';
import { AuthService } from './auth.service';
import { TimetableComponent } from './timetable/timetable.component';

export const routes: Routes = [
  { path: 'login', component: LoginComponent },
  {
    path: 'hotelinfo',
    component: HomeComponent,
    canActivate: [AuthService]
  },
  {
    path: 'guestinfo',
    component: GuestInfoComponent,
    canActivate: [AuthService]
  },
  {
    path: 'timetable',
    component: TimetableComponent,
    canActivate: [AuthService]
  },
  { path: '**', redirectTo: '/login' }
];
