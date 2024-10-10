import { Component, Input } from '@angular/core';
import { Day, ISlot, ITimetable } from '../itimetable';
import { CommonModule } from '@angular/common';
import { SlotComponent } from '../slot/slot.component';

@Component({
  selector: 'tbody[slots]',
  standalone: true,
  imports: [CommonModule, SlotComponent],
  templateUrl: './slots.component.html',
  styles: ``
})
export class SlotsComponent {
  @Input({ required: true }) day!: Day;
  @Input({ required: true }) hours!: number[];
  @Input({ required: true }) timetable!: ITimetable;
  @Input() pool: number = 0;
  items(day: Day, hour: number, areaId: string) {
    return this.timetable.Workshops.filter((slot) => {
      if (slot.Day !== day) return false;
      if (slot.Hour !== hour) return false;
      if (slot.AreaId !== areaId) return false;
      return true;
    });
  }
}
