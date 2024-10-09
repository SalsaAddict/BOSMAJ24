import { CommonModule, Time } from '@angular/common';
import { Component } from '@angular/core';
import {
  FormsModule,
  FormControl,
  FormGroup,
  ReactiveFormsModule
} from '@angular/forms';
import { TimetableClosedDirective } from '../timetable-closed.directive';
import {
  IWorkshop,
  TimetableDay,
  WorkshopComponent
} from '../workshop/workshop.component';
import { HttpClient } from '@angular/common/http';
import { AuthService } from '../auth.service';
import { BreakDirective } from './break.directive';

export interface ITimetable {
  Areas: {
    Id: string;
    Description: string;
  }[];
  Workshops: IWorkshop[];
}

@Component({
  selector: 'app-timetable',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    ReactiveFormsModule,
    TimetableClosedDirective,
    WorkshopComponent,
    BreakDirective
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
      });
  }
  timetable?: ITimetable;
  workshops(day: TimetableDay, hour: number, areaId: string) {
    return this.timetable?.Workshops.filter((workshop) => {
      if (workshop.Day !== day) return false;
      if (workshop.Hour !== hour) return false;
      if (workshop.AreaId !== areaId) return false;
      return true;
    });
  }
  get maxSpan() {
    return (this.timetable?.Areas.length ?? 0) + 1;
  }
  readonly options = new FormGroup({
    day: new FormControl<TimetableDay>('Fri')
  });
  get day() {
    return this.options.value.day!;
  }
}
