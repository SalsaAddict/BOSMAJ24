import { CommonModule } from '@angular/common';
import { Component, Input } from '@angular/core';

@Component({
  selector: 'tbody[break]',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './break.component.html',
  styles: ``
})
export class BreakComponent {
  @Input({ required: true }) areas!: number;
  @Input({ required: true }) hours!: number[];
  @Input({ required: true }) title!: string;
}
