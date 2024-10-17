import { CommonModule, DatePipe } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { Component } from '@angular/core';
import {
  IActivity,
  isActivity,
  isWorkshop,
  ITimetable,
  ITimetableItem
} from '../itimetable';
import { Category, Color } from '../color';
import { Timetable } from '../timetable';

interface IDayInfo {
  day: string;
  start: number;
  end: number;
}

interface IMealInfo {
  title: string;
  hour: number;
  hours: number;
}

@Component({
  selector: 'app-mobile',
  standalone: true,
  imports: [CommonModule],
  providers: [DatePipe],
  templateUrl: './mobile.component.html',
  styles: ``
})
export class MobileComponent {
  constructor(readonly http: HttpClient, private readonly datePipe: DatePipe) {
    Timetable.open().then((timetable) => {
      this.timetable = timetable;
    });
    this.setDay(this.days[0]);
  }
  timetable?: ITimetable;
  readonly days: IDayInfo[] = [
    { day: 'Thu', start: 16, end: 26 },
    { day: 'Fri', start: 8, end: 26 },
    { day: 'Sat', start: 8, end: 26 },
    { day: 'Sun', start: 8, end: 26 }
  ];
  day!: IDayInfo;
  get start() {
    return this.day.start;
  }
  get end() {
    return this.day.end;
  }
  hour!: number;
  time(hour: number, hours = 1) {
    let start = new Date(0),
      end = new Date(0);
    start.setHours(hour);
    end.setHours(hour + hours);
    return (
      this.datePipe.transform(start, 'HH:mm') +
      ' &ndash; ' +
      this.datePipe.transform(end, 'HH:mm')
    );
  }
  setDay(day: IDayInfo) {
    this.day = day;
    this.hour = day.start;
  }
  areaId?: string;
  toTime(hour: number) {
    let time = new Date(0);
    time.setHours(hour + (hour < this.day.start ? 24 : 0));
    return time;
  }
  getItems(day: string, hour: number, areaId?: string) {
    return this.timetable!.Items.filter((item) => {
      if (item.Day !== day) return false;
      if (areaId && item.AreaId !== areaId) return false;
      let hours = isActivity(item) ? item.Hours : 1;
      let now = this.toTime(hour),
        start = this.toTime(item.Hour),
        end = this.toTime(item.Hour + hours);
      if (now >= start && now < end) return true;
      return false;
    });
  }
  meals: IMealInfo[] = [
    { title: 'Breakfast', hour: 8, hours: 3 },
    { title: 'Lunch', hour: 13, hours: 2 },
    { title: 'Dinner', hour: 20, hours: 2 }
  ];
  meal(hour: number) {
    return this.meals.find((meal) => {
      return hour >= meal.hour && hour < meal.hour + meal.hours;
    });
  }
  getTitle(item: ITimetableItem) {
    return isWorkshop(item) ? item.Act : (item as IActivity).Title;
  }
  getSubtitle(item: ITimetableItem) {
    return isWorkshop(item) ? item.Title : (item as IActivity).Subtitle;
  }
  getDescription(item: ITimetableItem) {
    return isWorkshop(item) ? item.Level : (item as IActivity).Description;
  }
  bgImage(item: ITimetableItem | Category) {
    if (typeof item === 'string') {
      return Color.backgroundImage(item, 0.75);
    } else return Color.itemBackgroundImage(item);
  }
}
