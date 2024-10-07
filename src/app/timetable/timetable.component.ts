import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import {
  FormsModule,
  FormControl,
  FormGroup,
  ReactiveFormsModule
} from '@angular/forms';

@Component({
  selector: 'app-timetable',
  standalone: true,
  imports: [CommonModule, FormsModule, ReactiveFormsModule],
  templateUrl: './timetable.component.html',
  styles: ``
})
export class TimetableComponent {
  readonly options = new FormGroup({
    day: new FormControl<string>('Thu')
  });
}
