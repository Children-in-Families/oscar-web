db.createUser({
  user: 'oscar',
  pwd: '123456789',
  roles: [
    {
      role: 'readWrite',
      db: 'oscar_history_development',
    },
  ],
});