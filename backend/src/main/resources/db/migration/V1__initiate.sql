-- Добавление комнаты
insert into room (id, name) values ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Комната 1');

-- Добавление пользователя
insert into user_ (id, fio) values ('b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', 'Юзер 1');

-- Добавление бронирования
insert into booking (id, room_id, user_id, start_time, end_time, reserved, comment)
values ('c0eebc99-9c0b-4ef8-bb6d-6bb9bd380a33', 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'b0eebc99-9c0b-4ef8-bb6d-6bb9bd380a22', '2023-10-01 10:00:00', '2023-10-01 12:00:00', TRUE, 'Было тут изначально');