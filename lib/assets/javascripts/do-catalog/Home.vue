<template>
  <div class="home">
      <router-view></router-view>
    <NameBlock/>
  </div>
</template>

<script>
  import NameBlock from "./NameBlock";
  export default {
    components: {
      NameBlock
    }
  }
</script>