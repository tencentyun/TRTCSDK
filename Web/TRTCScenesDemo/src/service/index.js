

export async function getUsernameByUserid(userId) {
  return userId;
}

export async function getUserDetailInfoByUserid(userId) {
  return {
    name: userId,
    avatar: '',
    userId: userId
  };
}
