import { Component, ViewEncapsulation } from '@angular/core';
import { SystemService } from '../system.service';
import { Day, IActivity, ITimetable } from './itimetable';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { BreakComponent } from './break/break.component';
import { ActivitiesComponent } from './activities/activities.component';
import { TimeDirective } from './time.directive';
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-timetable',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    BreakComponent,
    ActivitiesComponent,
    TimeDirective
  ],
  templateUrl: './timetable.component.html',
  styleUrl: './timetable.component.css',
  encapsulation: ViewEncapsulation.None
})
export class TimetableComponent {
  private readonly activities: IActivity[] = [
    {
      AreaId: 'P',
      Day: 'Fri',
      Hour: 15,
      Hours: 3,
      Title: 'Pool Party',
      Category: 'Party'
    },
    {
      AreaId: 'P',
      Day: 'Sat',
      Hour: 15,
      Hours: 3,
      Title: 'Pool Party',
      Category: 'Party'
    },
    {
      AreaId: 'P',
      Day: 'Sun',
      Hour: 15,
      Hours: 2,
      Title: 'Pool Party',
      Category: 'Party'
    },
    {
      AreaId: 'P',
      Day: 'Sun',
      Hour: 17,
      Hours: 3,
      Title: 'Mega Pool Party',
      Subtitle: 'Dancing',
      Description: 'Animations &amp; Craziness',
      Category: 'Party'
    },
    {
      AreaId: 'S',
      Day: 'Sat',
      Hour: 10,
      Hours: 1,
      Title: 'Tech Rehearsal',
      Subtitle: '(Performers Only)',
      Category: 'Performance'
    },
    {
      AreaId: 'S',
      Day: 'Sat',
      Hour: 18,
      Hours: 2,
      Title: 'Shows',
      Category: 'Performance'
    },
    {
      AreaId: 'S',
      Day: 'Fri',
      Hour: 17,
      Hours: 1,
      Title: 'Jack &amp; Jill',
      Subtitle: 'Registration &amp; Sign-Up',
      Description: '(Competitors Only)',
      Category: 'Performance'
    },
    {
      AreaId: 'S',
      Day: 'Fri',
      Hour: 18,
      Hours: 2,
      Title: 'Jack &amp; Jill',
      Subtitle: 'Competition',
      Category: 'Performance'
    }
  ];
  constructor(
    private readonly http: HttpClient,
    private readonly system: SystemService
  ) {
    http.get<ITimetable>('assets/timetable.json').subscribe((teachers) => {
      this.timetable = teachers;
      this.timetable!.Items.push(...this.activities);
      this.days.forEach((day) => {
        let parties: IActivity[] = [
          {
            Day: day,
            AreaId: 'M',
            Hour: 22,
            Hours: 4,
            Title: 'Bachata Party',
            Subtitle: '100% Bachata',
            Category: 'Party'
          },
          {
            Day: day,
            AreaId: 'M',
            Hour: 2,
            Hours: 1,
            Title: '50/50 Party',
            Subtitle: 'Bachata &amp; Salsa',
            Category: 'Party'
          },
          {
            Day: day,
            AreaId: 'R',
            Hour: 22,
            Hours: 4,
            Title: 'Salsa Party',
            Subtitle: '100% Salsa',
            Category: 'Party'
          },
          {
            Day: day,
            AreaId: 'L',
            Hour: 22,
            Hours: 3,
            Title: 'Latino Party',
            Subtitle: 'Reggaeton &amp; More',
            Category: 'Party'
          }
        ];
        this.timetable!.Items.push(...parties);
      });
    });
  }
  timetable?: ITimetable;
  readonly days: Day[] = ['Thu', 'Fri', 'Sat', 'Sun'];
  set day(value: Day) {
    this.system.localStorage.setItem('Day', value);
  }
  get day() {
    return (this.system.localStorage.getItem('Day') ?? 'Thu') as Day;
  }
}
