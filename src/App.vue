<template>
  <v-app>
    <v-app-bar
      app
      color="primary"
      dark
    >

        <span class="mr-2">IMI Configuration Switcher</span>
    </v-app-bar>

    <v-content>
      <ChangeConfig></ChangeConfig>
    </v-content>
  </v-app>
</template>

<script>
import ChangeConfig from './components/ChangeConfig'

export default {
  name: 'App',
  components: {
    ChangeConfig
  },

  data: () => ({
    //
  }),
};
</script>
