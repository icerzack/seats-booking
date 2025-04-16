drop table IF EXISTS booking;
drop table IF EXISTS user_code;
drop table IF EXISTS user_;
drop table IF EXISTS room;

create TABLE room (
  id UUID NOT NULL PRIMARY KEY,
  name VARCHAR(2000)
);

create TABLE user_ (
  id UUID NOT NULL PRIMARY KEY,
  fio VARCHAR(8000)
);

create TABLE booking (
  id UUID NOT NULL PRIMARY KEY,
  room_id UUID REFERENCES room(id) ON delete CASCADE,
  user_id UUID REFERENCES user_(id) ON delete CASCADE,
  start_time TIMESTAMP WITHOUT TIME ZONE,
  end_time TIMESTAMP WITHOUT TIME ZONE,
  reserved BOOLEAN,
  comment VARCHAR(8000)
);

create TABLE user_code (
  id UUID NOT NULL PRIMARY KEY,
  code VARCHAR(2000),
  user_id UUID REFERENCES user_(id) ON delete CASCADE
);

create index idx_booking_room_id on booking (room_id);
create index idx_booking_user_id on booking (user_id);
create index idx_user_code_code on user_code (code);