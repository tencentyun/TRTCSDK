<template>
<div class="back-href-container">
    <div class="back-button">
        <router-link :to="href" v-if="href">
            <b-icon-chevron-left color="white"></b-icon-chevron-left>
        </router-link>
    </div>
    <h3 class="title" v-if="title">{{title}}</h3>
</div>

</template>

<script>


export default {
    props: {
        href: {
            type: String,
            required: false
        },
        title: {
            type: String,
            required: false
        }
    },
}

</script>
<style scoped>
.back-href-container {
    height: 5vh;
    line-height: 5vh;
    background-color: rgba(0,0,0, 0.5);
}
.back-button {
    display: inline-block;
    width: 5vw;
    text-align: center;
    font-size: 3vh;
}
.title {
    display: inline-block;
    margin: 0px;
    padding: 0px;
    top: 1vh;
    left: 0;
    text-align: center;
    color: #fff;
    width: 90vw;
    font-size: 2vh;
}
</style>
