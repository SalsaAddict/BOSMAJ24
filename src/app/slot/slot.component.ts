import { Component, Input } from '@angular/core';
import { IShow, ISlot, isWorkshop, IWorkshop } from '../itimetable';
import { CommonModule } from '@angular/common';

interface IColor {}

@Component({
  selector: 'app-slot',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './slot.component.html',
  styles: ``
})
export class SlotComponent {
  @Input({ required: true }) items?: ISlot[];
  isWorkshop(item: ISlot) {
    return isWorkshop(item);
  }
  asWorkshop(item: ISlot) {
    return item as IWorkshop;
  }
  asShow(item: ISlot) {
    return item as IShow;
  }
  private rgba(r: number, g: number, b: number, a: number) {
    return `rgba(${r}, ${g}, ${b}, ${a})`;
  }
  bgColor(item: ISlot) {
    if (isWorkshop(item)) {
      let a: number;
      switch (item.LevelId) {
        case 0:
          a = 0.2;
          break;
        case 1:
          a = 0.4;
          break;
        case 2:
          a = 0.6;
          break;
        case 3:
          a = 0.8;
          break;
        case 4:
          a = 1;
          break;
        default:
          a = 0;
          break;
      }
      switch (item.GenreId) {
        case 'B':
          return this.rgba(50, 255, 100, a);
        case 'S':
          return this.rgba(50, 150, 255, a);
        default:
          return this.rgba(255, 50, 50, a);
      }
    }
    return this.rgba(255, 200, 100, 1);
  }
}
