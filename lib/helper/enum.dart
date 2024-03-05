enum MessageType {
  text,
  image,
  file,
  custom,
  system,
}

enum CustomMessageType {
  material,
  assignment,
  quiz,
  uts,
  uas;
}

enum SystemMessageType {
  addMember,
  removeMember,
  createGroup,
  leaveGroup,
  deleteGroup,
  addZoom,
  removeZoom,
  session,
}
