import { CommonModule } from '@angular/common';
import { Component, Input } from '@angular/core';
import { TimeDirective } from '../time.directive';
import { IArea } from '../itimetable';

@Component({
  selector: 'tbody[break]',
  standalone: true,
  imports: [CommonModule, TimeDirective],
  templateUrl: './break.component.html',
  styles: ``
})
export class BreakComponent {
  @Input({ alias: 'break', required: true }) title!: string;
  @Input() subtitle?: string;
  @Input({ required: true }) hours!: number[];
  @Input({ required: true }) areas!: IArea[];
}
