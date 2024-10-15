import { Routes } from '@angular/router';
import { HomeComponent } from './home/home.component';
import { GuestInfoComponent } from './guest-info/guest-info.component';
import { LoginComponent } from './login/login.component';
import { SystemService } from './system.service';
import { TimetableComponent } from './timetable/timetable.component';
import { TeachersComponent } from './teachers/teachers.component';

export const routes: Routes = [
  { path: 'login', component: LoginComponent },
  {
    path: 'hotelinfo',
    component: HomeComponent,
    canActivate: [SystemService]
  },
  {
    path: 'guestinfo',
    component: GuestInfoComponent,
    canActivate: [SystemService]
  },
  {
    path: 'timetable',
    component: TimetableComponent
  },
  {
    path: 'teachers',
    component: TeachersComponent,
    canActivate: [SystemService]
  },
  { path: '**', redirectTo: '/timetable' }
];
