<template>
    <div id="screens-list">
        <div class="loading-animation" v-if="list.length===0">
            <b-icon icon="arrow-clockwise" animation="spin" font-scale="2" ></b-icon>
        </div>
        <div v-for="item in list" :key="item.sourceId" :label="item.sourceName" class="screen-info"  
            v-bind:data-id="item.sourceId"
            v-bind:data-name="item.sourceName"
            v-bind:data-type="item.type"
            @click="onChoose">
            <canvas :id="['screen_'+item.sourceId]" @onload="onCanvasLoaded"></canvas>
            <p>
                <b-button variant="link"> {{item.sourceName.length > 20 ? item.sourceName.slice(0,20)+'...' : item.sourceName }} </b-button>
            </p>
        </div>
    </div>   
</template>

<script>
import Log from '../common/log';
let logger = new Log('ShowScreenCapture');
export default {
    data() {
        return {

        };
    },

    props: {
        list: {
            type: Array,
            required: true
        },
        onClick : {
            type: Function,
            required: true
        },
    },

    methods: {

        onChoose (event) {
            try {
                this.onClick(event);
            } catch(err) {
                logger.log('onChoose error:', err);
            }
        },

        onCanvasLoaded(event) {
            logger.log('onCanvasLoaded:', event);
        },

        renderScreensList() {
            if (this.list.length === 0) {
                return;
            }
            let {list} = this;
            let srcInfos = null;
            let elId = '';
            let cnvs = null;
            let imgData = null;

            for (let i = 0; i < list.length; i++) {
                srcInfos = list[i];
                if (srcInfos.thumbBGRA.length===0) continue;
                elId = `screen_${srcInfos.sourceId}`;
                cnvs = document.getElementById(elId);
                cnvs.width = srcInfos.thumbBGRA.width;
                cnvs.height = srcInfos.thumbBGRA.height;
                imgData =  new ImageData(new Uint8ClampedArray(srcInfos.thumbBGRA.buffer), srcInfos.thumbBGRA.width,  srcInfos.thumbBGRA.height );
                cnvs.getContext("2d").putImageData(imgData, 0, 0);
            }
        },
    },

    mounted() {
        setTimeout(()=>{
            this.renderScreensList.bind(this)();
        }, 0);
    }

}

</script>

<style scoped>
#screens-list {
    text-align: center;
    align-content: center;
    height:70vh;
    overflow:auto;
}
.loading-animation {
    width:100vw;
    height: auto;
    text-align: center;
}
.screen-info {
    display: inline-block;
    text-align: center;
    margin: 10px;
    background-color: #fafafa;
}
.screen-info>p{
    margin: 0;
}
.screen-info>canvas{
    margin: 0;
}
.screen-info:hover {
    background-color: #f2f2f2;
    box-shadow: #333 0 0 10px;
}
.screen-info {
    cursor: pointer;
}
</style>
