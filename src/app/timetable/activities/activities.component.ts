import { Component, Input } from '@angular/core';
import {
  IActivity,
  IArea,
  isActivity,
  isWorkshop,
  ITimetable,
  ITimetableItem,
  IWorkshop,
  toTime
} from '../../itimetable';
import { CommonModule } from '@angular/common';
import { TimeDirective } from '../time.directive';
import { Color } from '../../color';

export type SlotType = 'Closed' | 'Activity' | 'Workshops';

@Component({
  selector: 'tbody[activities]',
  standalone: true,
  imports: [CommonModule, TimeDirective],
  templateUrl: './activities.component.html',
  styles: ``
})
export class ActivitiesComponent {
  @Input({ alias: 'activities', required: true }) timetable!: ITimetable;
  @Input({ required: true }) day!: string;
  @Input({ required: true }) hours!: number[];
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
    let color = Color.itemBackgroundImage(item);
    return color;
  }
}
