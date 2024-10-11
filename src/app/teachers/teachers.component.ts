import { HttpClient } from '@angular/common/http';
import { Component } from '@angular/core';
import { AuthService } from '../auth.service';
import { CommonModule, JsonPipe, TitleCasePipe } from '@angular/common';
import {
  FormGroup,
  FormControl,
  FormsModule,
  ReactiveFormsModule
} from '@angular/forms';

@Component({
  selector: 'app-teachers',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    ReactiveFormsModule,
    JsonPipe,
    TitleCasePipe
  ],
  templateUrl: './teachers.component.html',
  styles: ``
})
export class TeachersComponent {
  constructor(http: HttpClient, auth: AuthService) {
    auth
      .openEncryptedJsonFile<any[]>('assets/teachers.txt')
      .then((teachers) => {
        this.teachers = teachers;
      });
  }
  teachers?: any[];
  readonly options = new FormGroup({
    count: new FormControl<string>('All')
  });
  data() {
    return this.teachers?.filter((teacher) => {
      switch (this.options.value.count) {
        case '0':
          return teacher.TeacherCount === 0;
        case '1':
          return teacher.TeacherCount === 1;
        case '2+':
          return teacher.TeacherCount > 1;
        default:
          return true;
      }
    });
  }
  bgCount(count: number) {
    switch (count) {
      case 0:
        return 'text-bg-danger';
      case 1:
        return 'text-bg-warning';
      default:
        return 'text-bg-success';
    }
  }
}
