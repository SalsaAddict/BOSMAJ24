import { Component, Input } from '@angular/core';
import {
  Day,
  IActivity,
  IArea,
  isActivity,
  isWorkshop,
  ITimetable,
  ITimetableItem,
  IWorkshop,
  toTime
} from '../itimetable';
import { CommonModule } from '@angular/common';
import { TimeDirective } from '../time.directive';

type SlotType = 'Closed' | 'Activity' | 'Workshops';

@Component({
  selector: 'tbody[activities]',
  standalone: true,
  imports: [CommonModule, TimeDirective],
  templateUrl: './activities.component.html',
  styles: ``
})
export class ActivitiesComponent {
  @Input({ alias: 'activities', required: true }) timetable!: ITimetable;
  @Input({ required: true }) day!: Day;
  @Input({ required: true }) hours!: number[];
  @Input({ required: true }) pool!: { [day: string]: number };
  slot(hour: number, area: IArea) {
    return this.timetable.Items.filter((item) => {
      if (item.AreaId !== area.Id) return false;
      if (item.Day !== this.day) return false;
      if (item.Hour !== hour) return false;
      return true;
    });
  }
  rowspan(item: ITimetableItem) {
    return isActivity(item) ? item.Hours : 1;
  }
  skip(hour: number, area: IArea) {
    let item = this.timetable.Items.find((item) => {
      if (item && isActivity(item)) {
        if (item.AreaId !== area.Id) return false;
        if (item.Day !== this.day) return false;
        let time = toTime(hour);
        let startTime = toTime(item.Hour);
        let endTime = toTime(item.Hour + item.Hours - 1);
        if (time > startTime && time <= endTime) return true;
        return false;
      } else return false;
    });
    return !!item;
  }
  activity(hour: number, area: IArea) {
    return this.slot(hour, area)[0] as IActivity;
  }

  closed(hour: number, area: IArea) {
    return this.slot(hour, area).length === 0;
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
  bgImage(item: ITimetableItem | ITimetableItem[]) {
    if (Array.isArray(item)) return;
    let rgb: [number, number, number];
    let a: number;
    if (isWorkshop(item)) {
      switch (item.GenreId) {
        case 'B':
          rgb = [100, 255, 150];
          break;
        case 'S':
          rgb = [140, 200, 255];
          break;
        case 'O':
          rgb = [180, 100, 255];
          break;
        default:
          return;
      }
      a = (item.LevelId + 1) * 0.2;
    } else {
      switch ((item as IActivity).Category) {
        case 'Party':
          rgb = [255, 220, 80];
          break;
        case 'Performance':
          rgb = [255, 150, 127];
          break;
        default:
          return;
      }
      a = 1;
    }
    return `radial-gradient(circle, rgba(${rgb[0]}, ${rgb[1]}, ${rgb[2]}, ${
      a - 0.1
    }), rgba(${rgb[0] - 50}, ${rgb[1] - 50}, ${rgb[2] - 50}, ${a}))`;
  }
}
