import { CommonModule } from '@angular/common';
import { Component, Input } from '@angular/core';

export type TimetableDay = 'Thu' | 'Fri' | 'Sat' | 'Sun';

export interface ISlot {
  Day: TimetableDay;
  Hour: number;
  AreaId: string;
}

export interface IShow extends ISlot {
  title: string;
  subtitle?: string;
}

export interface IWorkshop extends ISlot {
  Act: string;
  Title: string;
  LevelId: number;
  Level: string;
  GenreId: string;
}

@Component({
  selector: 'app-workshop',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './workshop.component.html',
  styles: ``
})
export class WorkshopComponent {
  @Input() workshops?: IWorkshop[];
  bgColor(workshop: IWorkshop) {
    let color: string;
    switch (workshop.GenreId) {
      case 'B':
        color = '50,180,255';
        break;
      case 'S':
        color = '0,255,50';
        break;
      default:
        color = '255,127,127';
        break;
    }
    switch (workshop.LevelId) {
      case 0:
        color += ',0.25';
        break;
      case 1:
        color += ',0.5';
        break;
      case 2:
        color += ',0.75';
        break;
      default:
        color += ',1';
    }
    console.debug(color);
    return `rgba(${color})`;
  }
}
