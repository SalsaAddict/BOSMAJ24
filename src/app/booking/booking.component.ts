import { HttpClient } from '@angular/common/http';
import { Component } from '@angular/core';
import { Guest, HotelInfo, Room } from '../hotel-info';
import { CommonModule, JsonPipe } from '@angular/common';

@Component({
  selector: 'app-booking',
  standalone: true,
  imports: [CommonModule, JsonPipe],
  templateUrl: './booking.component.html',
  styles: ``
})
export class BookingComponent {
  constructor(private readonly http: HttpClient) {
    this.http.get<HotelInfo>('/assets/hotel.json').subscribe((data) => {
      data.RoomTypes.every((roomType) => {
        return roomType.Rooms.every((room) => {
          return room.Guests.every((guest) => {
            if (guest.Reference === '2WD3-7JHN-86F1Q') {
              this.roomType = roomType.Description;
              this.guest = guest;
              this.room = room;
              return false;
            }
            return true;
          });
        });
      });
    });
  }
  roomType?: string;
  guest?: Guest;
  room?: Room;
}
