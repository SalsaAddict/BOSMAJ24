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
    let r, g, b, a, a2: number;
    if (isWorkshop(item)) {
      switch (item.GenreId) {
        case 'B':
          r = 50;
          g = 255;
          b = 100;
          break;
        case 'S':
          r = 50;
          g = 150;
          b = 255;
          break;
        default:
          r = 255;
          g = 50;
          b = 255;
          break;
      }
      a = (item.LevelId + 1) * 0.2;
    } else {
      r = 255;
      g = 100;
      b = 100;
      a = 1;
    }
    return `radial-gradient(circle, ${this.rgba(
      r,
      g,
      b,
      a - 0.1
    )}, 75%, ${this.rgba(r - 50, g - 50, b - 50, a)})`;
  }
}
