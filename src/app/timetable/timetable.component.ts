import { CommonModule, Time } from '@angular/common';
import { Component } from '@angular/core';
import {
  FormsModule,
  FormControl,
  FormGroup,
  ReactiveFormsModule,
  Validators
} from '@angular/forms';
import { HttpClient } from '@angular/common/http';
import { AuthService } from '../auth.service';
import { Day, IShow, ITimetable } from '../itimetable';
import { SlotComponent } from '../slot/slot.component';
import { SlotsComponent } from '../slots/slots.component';
import { BreakComponent } from '../break/break.component';

@Component({
  selector: 'app-timetable',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    ReactiveFormsModule,
    BreakComponent,
    SlotComponent,
    SlotsComponent
  ],
  templateUrl: './timetable.component.html',
  styles: ``
})
export class TimetableComponent {
  constructor(http: HttpClient, auth: AuthService) {
    auth
      .openEncryptedJsonFile<ITimetable>('assets/timetable.txt')
      .then((timetable) => {
        this.timetable = timetable;
        this.timetable.Workshops.push({
          Day: 'Fri',
          Hour: 17,
          AreaId: 'S',
          Title: 'Jack & Jill',
          Subtitle: 'Sign-Up & Briefing'
        } as IShow);
        this.timetable.Workshops.push({
          Day: 'Fri',
          Hour: 18,
          AreaId: 'S',
          Title: 'Jack & Jill',
          Subtitle: 'Competition'
        } as IShow);
        this.timetable.Workshops.push({
          Day: 'Sat',
          Hour: 10,
          AreaId: 'S',
          Title: 'Tech Rehearsal',
          Subtitle: '(Performers Only)'
        } as IShow);
        this.timetable.Workshops.push({
          Day: 'Sat',
          Hour: 18,
          AreaId: 'S',
          Title: 'SHOWTIME!'
        } as IShow);
      });
  }
  timetable?: ITimetable;
  readonly options = new FormGroup({
    day: new FormControl<Day>('Thu', [Validators.required])
  });
  get day() {
    return this.options.value.day!;
  }
  readonly slots = {
    am: [10, 11, 12],
    pm: [15, 16, 17]
  };
  items(day: Day, hour: number, areaId: string) {
    return this.timetable?.Workshops.filter((slot) => {
      if (slot.Day !== day) return false;
      if (slot.Hour !== hour) return false;
      if (slot.AreaId !== areaId) return false;
      return true;
    });
  }
}
