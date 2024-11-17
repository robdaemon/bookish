000100241116**free
000101241116
000102241116dcl-ds user qualified;
000103241116  id int(10);
000104241116  email varchar(50);
000105241116  name varchar(100);
000106241116  password_hash varchar(100);
000107241116  created_at timestamp;
000108241116  updated_at timestamp;
000109241116end-ds;
000110241116
000111241116dcl-ds books qualified;
000112241116  id int(10);
000113241116  title varchar(100);
000114241116  author varchar(100);
000115241116  isbn10 varchar(10);
000116241116  created_at timestamp;
000117241116  created_by likeds(user);
000118241116  updated_at timestamp;
000119241116  updated_by likeds(user);
000120241116end-ds;
000121241116
000122241116dcl-ds users_books qualified;
000123241116  user_id int(10);
000124241116  book likeds(books);
000125241116  reading_status varchar(50);
000126241116end-ds;
000127241116
