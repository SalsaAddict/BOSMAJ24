import { CommonModule, JsonPipe } from '@angular/common';
import { HttpClient, JsonpClientBackend } from '@angular/common/http';
import { Component } from '@angular/core';
import { HotelInfo } from '../hotel-info';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [CommonModule, JsonPipe],
  templateUrl: './home.component.html',
  styleUrl: './home.component.css'
})
export class HomeComponent {
  constructor(private readonly http: HttpClient) {
    this.http.get<HotelInfo>('/assets/hotel.json').subscribe((data) => {
      this.hotel = data;
    });
  }
  hotel?: HotelInfo;
}
