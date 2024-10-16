import { Routes } from '@angular/router';
import { HomeComponent } from './home/home.component';
import { GuestInfoComponent } from './guest-info/guest-info.component';
import { LoginComponent } from './login/login.component';
import { SystemService } from './system.service';
import { TimetableComponent } from './timetable/timetable.component';
import { TeachersComponent } from './teachers/teachers.component';

function title(text: string) {
  return `BOS Majorca 2024 - ${text}`;
}

export const routes: Routes = [
  { path: 'login', component: LoginComponent },
  {
    path: 'hotelinfo',
    component: HomeComponent,
    canActivate: [SystemService],
    title: title('Rooms')
  },
  {
    path: 'guestinfo',
    component: GuestInfoComponent,
    canActivate: [SystemService],
    title: title('Guests')
  },
  {
    path: 'timetable',
    component: TimetableComponent,
    title: title('Timetable')
  },
  {
    path: 'teachers',
    component: TeachersComponent,
    canActivate: [SystemService],
    title: title('Teachers')
  },
  { path: '**', redirectTo: '/timetable' }
];
