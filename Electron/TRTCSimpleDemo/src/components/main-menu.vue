<template name="main-menu">

  <div class="main-menu">
    <ul>
      <li> <router-link to="/trtc-index" > RTC </router-link> </li>
      <li> <router-link to="/live-index/anchor" > LIVE </router-link> </li>
    </ul>
  </div>
</template>

<script>
export default {
  name: "main-menu",
}
</script>

<style scoped>
.main-menu{
  font-size: 2em;
}
.main-menu>ul {
    display: block;
    list-style: none;
    margin: 30vh auto 5vh auto;
    width: 50%;
    padding: 0;
}
.main-menu>ul>li {
    margin: 2px 5px;
    height: 2em;
    line-height: 2em;
    text-align: center;
}
.main-menu>ul>li>a {
    color: #fff;
    text-decoration: none;
    display: block;
    border-radius: 5px;
    height: 2em;
    line-height: 2em;
    margin: 1em;
    background-color: #007bff;
}
.main-menu>ul>li>a:hover {
  background-color: #0069d9;
}
</style>
<style>

</style>