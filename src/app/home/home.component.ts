import { CommonModule } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { Component, ViewEncapsulation } from '@angular/core';
import { IHotelInfo } from '../hotel-info';
import { SystemService } from '../system.service';
import { NameComponent } from '../name/name.component';

@Component({
  selector: 'app-home',
  standalone: true,
  imports: [CommonModule, NameComponent],
  templateUrl: './home.component.html',
  encapsulation: ViewEncapsulation.None
})
export class HomeComponent {
  constructor(http: HttpClient, auth: SystemService) {
    auth
      .openEncryptedJsonFile<IHotelInfo>('assets/hotelinfo.txt')
      .then((info) => {
        this.info = info;
      });
  }
  info?: IHotelInfo;
}
