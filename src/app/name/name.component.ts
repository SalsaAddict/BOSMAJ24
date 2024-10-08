import { TitleCasePipe } from '@angular/common';
import { Component, Input } from '@angular/core';

@Component({
  selector: 'app-name',
  standalone: true,
  imports: [TitleCasePipe],
  template: `<span class="text-capitalize">{{
    text || '&ndash;' | titlecase
  }}</span>`
})
export class NameComponent {
  @Input() text = '';
}
