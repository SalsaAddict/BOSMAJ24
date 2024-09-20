import { Routes } from '@angular/router';
import { HomeComponent } from './home/home.component';
import { BookingComponent } from './booking/booking.component';

export const routes: Routes = [
  { path: 'hotelinfo', component: HomeComponent },
  { path: 'booking', component: BookingComponent },
  { path: '**', redirectTo: '/booking' }
];
