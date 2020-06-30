db.createUser({
  user: "oscar",
  pwd: '123456789',
  customData: { employeeId: 12345 },
  roles: [
    { role: "clusterAdmin", db: "admin" },
    { role: "readAnyDatabase", db: "admin" },
    "readWrite"
  ]},
  { w: "majority" , wtimeout: 5000 }
);