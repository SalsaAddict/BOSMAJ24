import { CommonModule, DatePipe } from '@angular/common';
import { HttpClient } from '@angular/common/http';
import { Component } from '@angular/core';
import {
  IActivity,
  IDay,
  isActivity,
  isWorkshop,
  ITimetable,
  ITimetableItem
} from '../itimetable';
import { Category, Color } from '../color';
import { Timetable } from '../timetable';

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
      this.setNow();
    });
  }
  timetable?: ITimetable;
  day!: IDay;
  get start() {
    return this.day.Start;
  }
  get end() {
    return this.day.End;
  }
  get today() {
    let weekday = new Date(Date.now())
      .toLocaleDateString('en-GB', {
        weekday: 'short'
      })
      .toLocaleLowerCase();
    let day = this.timetable!.Days.find((item) => {
      return item.Day.toLocaleLowerCase() === weekday;
    });
    return day ?? this.timetable!.Days[0];
  }
  hour!: number;
  get now() {
    return Number(
      new Date(Date.now()).toLocaleTimeString('en-GB', { hour: '2-digit' })
    );
  }
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
  setDay(day: IDay, hour?: number) {
    this.day = day;
    if (hour === undefined) {
      this.hour = day.Start;
    } else {
      let now = this.toTime(hour),
        start = this.toTime(this.today.Start),
        end = this.toTime(this.today.End);
      if (now >= start && now < end) this.hour = hour;
      else this.hour = this.today.Start;
    }
  }
  setNow() {
    this.setDay(this.today, this.now);
  }
  areaId?: string;
  toTime(hour: number) {
    let time = new Date(0);
    time.setHours(hour + (hour < this.day.Start ? 24 : 0));
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
