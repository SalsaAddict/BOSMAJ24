import { Component, Input } from '@angular/core';
import { CommonModule, TitleCasePipe } from '@angular/common';

@Component({
  selector: 'app-guest-detail',
  standalone: true,
  imports: [CommonModule, TitleCasePipe],
  templateUrl: './guest-detail.component.html',
  styles: ``
})
export class GuestDetailComponent {
  @Input() condition!: boolean | undefined;
  @Input() value!: string | undefined;
  @Input() normalize = false;
  @Input() nullClass = 'bi-question-octagon-fill text-warning';
}
