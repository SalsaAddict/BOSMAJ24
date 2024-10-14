import { Component, ViewEncapsulation } from '@angular/core';
import {
  FormsModule,
  ReactiveFormsModule,
  FormGroup,
  FormControl
} from '@angular/forms';
import { IGuestInfo } from '../guest-info';
import { CommonModule, TitleCasePipe } from '@angular/common';
import { SystemService } from '../system.service';
import { GuestDetailComponent } from '../guest-detail/guest-detail.component';

type GuestType = 'All' | 'Staff' | 'Guests';
type ReviewType = 'All' | 'Question' | 'Problem' | 'Random';

@Component({
  selector: 'app-guest-info',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    ReactiveFormsModule,
    TitleCasePipe,
    GuestDetailComponent
  ],
  templateUrl: './guest-info.component.html',
  encapsulation: ViewEncapsulation.None
})
export class GuestInfoComponent {
  constructor(auth: SystemService) {
    auth
      .openEncryptedJsonFile<IGuestInfo[]>('assets/guestinfo.txt')
      .then((info) => {
        this.info = info;
      });
  }
  info: IGuestInfo[] = [];
  color(value?: boolean) {
    if (value === true) return;
    if (value === false) return 'text-danger';
    return 'text-warning';
  }

  readonly searchForm = new FormGroup({
    type: new FormControl<GuestType>('All'),
    name: new FormControl<string>(''),
    reference: new FormControl<string>(''),
    linkId: new FormControl<number | undefined>(undefined),
    review: new FormControl<ReviewType>('All')
  });

  link(guestId: number) {
    this.searchForm.patchValue({ linkId: guestId });
  }
  unlink() {
    this.searchForm.patchValue({ linkId: undefined });
  }

  guests(): IGuestInfo[] {
    if (this.info?.length) {
      if (this.searchForm.value.linkId) {
        return this.info.filter((guest) => {
          if (guest.GuestId === this.searchForm.value.linkId) return true;
          if (guest.SharingWithId === this.searchForm.value.linkId) return true;
          return false;
        });
      }
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
        })
        .filter((guest) => {
          switch (this.searchForm.value.review!) {
            case 'All':
              return true;
            case 'Question':
              return guest.HasQuestion;
            case 'Problem':
              return guest.HasProblem;
            case 'Random':
              return !guest.Confirmed;
          }
        });
    } else return [];
  }
  total(staff?: boolean) {
    if (staff === undefined) return this.info.length;
    return this.info.filter((guest) => {
      return guest.Staff == staff;
    }).length;
  }
  get count() {
    return this.guests().length;
  }
  get filtered() {
    return this.count !== this.info.length;
  }
}
