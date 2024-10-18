import { HttpClient } from '@angular/common/http';
import { ITimetable } from './itimetable';
import { firstValueFrom } from 'rxjs';
import { inject } from '@angular/core';

export class Timetable {
  constructor(private readonly http: HttpClient) {}
  static async open(http = inject(HttpClient)) {
    let timetable = await firstValueFrom(
      http.get<ITimetable>('assets/timetable.json')
    );
    return timetable;
  }
}
