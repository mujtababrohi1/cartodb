<template>
  <div id="do-catalog">
    <Home/>
  </div>
</template>

<script>
import Home from './Home'
export default {
  name: 'do-catalog',
  components: {
    Home
  }
}
</script>

<style>
  #do-catalog {
    font-family: 'Avenir', Helvetica, Arial, sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    text-align: center;
    color: #2c3e50;
    margin-top: 60px;
  }
</style>