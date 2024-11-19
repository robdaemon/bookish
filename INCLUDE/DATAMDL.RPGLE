**free

dcl-ds user qualified;
  id int(10);
  email varchar(50);
  name varchar(100);
  password_hash varchar(100);
  created_at timestamp;
  updated_at timestamp;
end-ds;

dcl-ds books qualified;
  id int(10);
  title varchar(100);
  author varchar(100);
  isbn10 varchar(10);
  created_at timestamp;
  created_by likeds(user);
  updated_at timestamp;
  updated_by likeds(user);
end-ds;

dcl-ds users_books qualified;
  user_id int(10);
  book likeds(books);
  reading_status varchar(50);
end-ds;

