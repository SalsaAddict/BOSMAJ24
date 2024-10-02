import { Component, ViewEncapsulation } from '@angular/core';
import {
  FormsModule,
  ReactiveFormsModule,
  FormGroup,
  FormControl
} from '@angular/forms';
import { IGuestInfo } from '../guest-info';
import { CommonModule, JsonPipe, TitleCasePipe } from '@angular/common';
import { AuthService } from '../auth.service';

type GuestType = 'All' | 'Staff' | 'Guests';

@Component({
  selector: 'app-guest-info',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    ReactiveFormsModule,
    JsonPipe,
    TitleCasePipe
  ],
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

  readonly searchForm = new FormGroup({
    type: new FormControl<GuestType>('All'),
    name: new FormControl<string>(''),
    reference: new FormControl<string>(''),
    linkId: new FormControl<number | undefined>(undefined)
  });

  guests(): IGuestInfo[] {
    if (this.info?.length) {
      return this.info
        .filter((guest) => {
          if (this.searchForm.value.type === 'Staff' && !guest.Staff)
            return false;
          if (this.searchForm.value.type === 'Guests' && guest.Staff)
            return false;
          return true;
        })
        .filter((guest) => {
          if (!this.searchForm.value.name?.length) return true;
          if (
            guest.FullName.toLowerCase().includes(
              this.searchForm.value.name.toLowerCase()
            )
          ) {
            return true;
          }
          if (
            guest.SharingWith?.length &&
            guest.SharingWith.toLowerCase().includes(
              this.searchForm.value.name.toLowerCase()
            )
          ) {
            return true;
          }
          return false;
        })
        .filter((guest) => {
          if (!this.searchForm.value.reference?.length) return true;
          if (
            guest.TicketId?.length &&
            guest.TicketId.toLowerCase().includes(
              this.searchForm.value.reference.toLowerCase()
            )
          ) {
            return true;
          }
          return false;
        });
    } else return [];
  }
}
