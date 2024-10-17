import { Component, Input, ViewEncapsulation } from '@angular/core';
import { SystemService } from '../system.service';
import { ITimetable } from '../itimetable';
import { FormsModule } from '@angular/forms';
import { CommonModule, TitleCasePipe } from '@angular/common';
import { BreakComponent } from './break/break.component';
import { ActivitiesComponent } from './activities/activities.component';
import { TimeDirective } from './time.directive';
import { RouterLink, RouterLinkActive } from '@angular/router';
import { Category, Color } from '../color';
import { Timetable } from '../timetable';

@Component({
  selector: 'app-timetable',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    RouterLink,
    RouterLinkActive,
    BreakComponent,
    ActivitiesComponent,
    TimeDirective
  ],
  providers: [TitleCasePipe],
  templateUrl: './timetable.component.html',
  styleUrl: './timetable.component.css',
  encapsulation: ViewEncapsulation.None
})
export class TimetableComponent {
  constructor(
    private readonly system: SystemService,
    private readonly titleCase: TitleCasePipe
  ) {
    Timetable.open().then((timetable) => {
      this.timetable = timetable;
    });
  }
  timetable?: ITimetable;
  readonly days: string[] = ['Thu', 'Fri', 'Sat', 'Sun'];
  @Input() set day(value: string) {
    this.system.localStorage.setItem('Day', this.titleCase.transform(value));
  }
  get day() {
    return this.system.localStorage.getItem('Day') ?? 'Thu';
  }
  bgImage(category: Category, opacity: number) {
    return Color.backgroundImage(category, opacity);
  }
}
