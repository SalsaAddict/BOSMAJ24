import { Component, ViewEncapsulation } from '@angular/core';
import { IGuestInfo } from '../guest-info';
import { CommonModule, JsonPipe, TitleCasePipe } from '@angular/common';
import { AuthService } from '../auth.service';

@Component({
  selector: 'app-guest-info',
  standalone: true,
  imports: [CommonModule, JsonPipe, TitleCasePipe],
  templateUrl: './guest-info.component.html',
  encapsulation: ViewEncapsulation.None
})
export class GuestInfoComponent {
  constructor(auth: AuthService) {
    auth
      .openEncryptedJsonFile<IGuestInfo[]>('/assets/guestinfo.txt')
      .then((info) => {
        this.info = info;
      });
  }
  info?: IGuestInfo[];
  color(value?: boolean) {
    if (value === true) return;
    if (value === false) return 'text-danger';
    return 'text-warning';
  }
}
